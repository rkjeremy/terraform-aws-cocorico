import zlib from "zlib";
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";

const snsClient = new SNSClient({});

let input = {
  // PublishInput
  TopicArn: process.env.TOPIC_ARN,
  Subject: "Cocorico alert",
  Message: "hello from hell",
};

export const handler = async (event, context) => {
  let payload = Buffer.from(event.awslogs.data, "base64");
  zlib.gunzip(payload, async (e, result) => {
    if (e) {
      context.fail(e);
      return JSON.stringify(e);
    } else {
      let temp = JSON.parse(result.toString());
      console.log("Event Data:", JSON.stringify(temp, null, 2));
      // context.succeed();

      try {
        const response = await snsClient.send(new PublishCommand(input));
        console.log({ response });

        return {
          statusCode: 200,
          body: JSON.stringify({
            message: "Message successfully sent to SNS!",
            messageId: response.MessageId,
          }),
        };
      } catch (error) {
        console.error("Error publishing message:", error);
        return {
          statusCode: 500,
          body: JSON.stringify({
            message: "Failed to send message to SNS",
            error: error.message,
          }),
        };
      }
    }
  });
};
