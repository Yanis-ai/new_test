/*
 * (c) DOCOMO ANIME STORE inc, All Right Reserved.
 */
package jp.co.nttdocomo.serverfence.lb.batch.geoCheckResultSeparation.logic;

import com.google.gson.Gson;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.DeleteMessageRequest;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;
import software.amazon.awssdk.utils.IoUtils;
import software.amazon.awssdk.utils.StringInputStream;
import software.amazon.awssdk.utils.Zstd;
import software.amazon.awssdk.utils.Zstd.ZstdInputStream;
import software.amazon.awssdk.utils.Zstd.ZstdOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import jp.co.nttdocomo.serverfence.lb.batch.base.BaseLogic;
import jp.co.nttdocomo.serverfence.lb.batch.common.dto.ConfigDto;
import lombok.extern.slf4j.Slf4j;
import java.util.concurrent.ExecutorService;

@Service(value = "geoCheckResultSeparation")
@Slf4j
public class GeoCheckResultSeparationLogic extends BaseLogic {

    @Autowired
    private ConfigDto config;

    @Autowired
    private ExecutorService executorService;

    @Override
    public void execute(String[] args) throws Exception {
        log.info("geoCheckResultSeparation logic start");
        SqsClient sqsClient = SqsClient.builder().region(Region.AP_NORTHEAST_1).build();
        S3Client s3Client = S3Client.builder().region(Region.AP_NORTHEAST_1).build();
        String sqsQueueUrl = config.getAws().getSqs();

        while (true) {
            ReceiveMessageRequest receiveMessageRequest = ReceiveMessageRequest.builder()
                   .queueUrl(sqsQueueUrl)
                   .maxNumberOfMessages(10)
                   .build();
            ReceiveMessageResponse receiveMessageResponse = sqsClient.receiveMessage(receiveMessageRequest);
            List<Message> messages = receiveMessageResponse.messages();

            for (Message message : messages) {
                executorService.submit(() -> {
                    try {
                        // 消息解析
                        Gson gson = new Gson();
                        MessageBody messageBody = gson.fromJson(message.body(), MessageBody.class);
                        String bucketName = messageBody.bucketName;
                        String filePath = messageBody.filePath;

                        // 文件下载
                        String tempDir = config.getAws().getS3() + "/temp/" + UUID.randomUUID() + "/";
                        Path tempDirPath = Paths.get(tempDir);
                        Files.createDirectories(tempDirPath);
                        String downloadedFilePath = tempDir + filePath.substring(filePath.lastIndexOf("/") + 1);
                        GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                               .bucket(bucketName)
                               .key(filePath)
                               .build();
                        try (GetObjectResponse getObjectResponse = s3Client.getObject(getObjectRequest);
                             FileOutputStream fos = new FileOutputStream(downloadedFilePath)) {
                            IoUtils.copy(getObjectResponse, fos);
                        } catch (IOException e) {
                            log.error("文件下载失败: {}", e.getMessage());
                            return;
                        }

                        // 时间戳获取
                        String timestamp = extractTimestampFromFileName(filePath);
                        if (timestamp == null) {
                            log.error("无法从文件名中提取时间戳: {}", filePath);
                            return;
                        }

                        // 解压firehorse文件
                        String firehorseExtractDir = tempDir + "extracted_firehorse/";
                        Path firehorseExtractDirPath = Paths.get(firehorseExtractDir);
                        Files.createDirectories(firehorseExtractDirPath);
                        extractFirehorseFile(downloadedFilePath, firehorseExtractDir);

                        // 解压Zstandard文件
                        File firehorseExtractDirFile = new File(firehorseExtractDir);
                        File[] zstdFiles = firehorseExtractDirFile.listFiles((dir, name) -> name.endsWith(".zst"));
                        if (zstdFiles != null) {
                            for (File zstdFile : zstdFiles) {
                                String zstdExtractDir = firehorseExtractDir + "extracted_zstd/";
                                Path zstdExtractDirPath = Paths.get(zstdExtractDir);
                                Files.createDirectories(zstdExtractDirPath);
                                String zstdExtractFilePath = zstdExtractDir + zstdFile.getName().replace(".zst", "");
                                try (ZstdInputStream zstdInputStream = new ZstdInputStream(new FileInputStream(zstdFile));
                                     FileOutputStream zstdFos = new FileOutputStream(zstdExtractFilePath)) {
                                    IoUtils.copy(zstdInputStream, zstdFos);
                                } catch (IOException e) {
                                    log.error("解压Zstandard文件失败: {}", e.getMessage());
                                }
                            }
                        }

                        // 处理完成后删除SQS消息
                        DeleteMessageRequest deleteMessageRequest = DeleteMessageRequest.builder()
                               .queueUrl(sqsQueueUrl)
                               .receiptHandle(message.receiptHandle())
                               .build();
                        sqsClient.deleteMessage(deleteMessageRequest);
                    } catch (Exception e) {
                        log.error("处理消息时发生异常: {}", e.getMessage());
                    }
                });
            }
        }
    }

    private String extractTimestampFromFileName(String fileName) {
        Pattern pattern = Pattern.compile("((\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2}))");
        Matcher matcher = pattern.matcher(fileName);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private void extractFirehorseFile(String firehorseFilePath, String extractDir) throws IOException {
        try (FileInputStream fis = new FileInputStream(firehorseFilePath);
             FileOutputStream fos = new FileOutputStream(extractDir + "extracted_file")) {
            byte[] buffer = new byte[1024];
            int length;
            while ((length = fis.read(buffer)) != -1) {
                fos.write(buffer, 0, length);
            }
        }
    }

    private static class MessageBody {
        String bucketName;
        String filePath;
    }
}
