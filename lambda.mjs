import zlib from "zlib";
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";

const snsClient = new SNSClient({});

let input = {
  // PublishInput
  TopicArn: process.env.TOPIC_ARN,
  Subject: `${process.env.PROJECT_NAME} Alert`,
  Message: `
  Chers administrateurs,
  Un changement a eu lieu dans votre compte AWS 
  `,
};

export const handler = (event, context) => {
  let payload = Buffer.from(event.awslogs.data, "base64");
  zlib.gunzip(payload, async (e, result) => {
    if (e) {
      context.fail(e);
      return JSON.stringify(e);
    } else {
      let eventData = JSON.parse(result.toString());
      input.Message = `
        Chers administrateurs,
        Un changement a eu lieu dans votre compte AWS portant l'ID ${eventData.owner}. Veuillez consulter le Log Stream portant le nom ${eventData.logStream} dans votre Cloudwatch 
        Log Group ${eventData.logGroup} pour avoir plus de détails.
        `;
      try {
        // input.Message = JSON.stringify(temp);
        const response = await snsClient.send(new PublishCommand(input));
        // console.log({ response });

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
