const randomBytes = require('crypto').randomBytes;
const AWS = require('aws-sdk');

exports.handler = async (event, context) => {
    let allMessages = [];
    let done = false;
    while(!done) {
        console.log("gettin gmessages");
        try {
            let messages = await getMessages();
            if("Messages" in messages) {
                console.log("Got Messages:");
                console.log(messages);
                allMessages.push(...messages.Messages);
            } else {
                console.log("No more messages in queue");
                done = true;
            }
        } catch(err) {
            console.log("Error");
            console.error(err);
            context.fail(err);
        }
    }
    console.log(allMessages);
    console.log("creating CSV")
    if(allMessages.length > 0) {
        const csv = createCsv(allMessages);

        try {
            const now = new Date();
            const time = now.getTime();
            const day = String(now.getDate()).padStart(2,'0');
            const month = String(now.getMonth() + 1).padStart(2,'0');
            const year = now.getFullYear();
            const dateString = `${month}${day}${year}`
            const filename = `${dateString}/sqs_events_${time}.csv`
            let res = await writeToS3(csv, filename);
            console.log(`File uploaded to s3 successfully at ${res.Location}`);

            const message = {
              filename: filename,
              timestamp: time
            }
            res = await notifySNS(message);
            context.succeed(`Successfully parsed SQS into a CSV and notified SNS`);            
        } catch(err) {
            console.error(err);
            context.fail(err);
        };
    } else {
        context.succeed(`Successful, no messages in queue`);
    }
};

async function getMessages() {
    // SQS code here
    const sqs = new AWS.SQS({apiVersion: '2012-11-05'});
    let params = {
        QueueUrl: process.env.SQS_QUEUE_URL,
        MaxNumberOfMessages: process.env.SQS_BATCH_SIZE,
        WaitTimeSeconds: 0,
        VisibilityTimeout: 10
    };
    let messages = sqs.receiveMessage(params).promise();
    return messages;
}

function createCsv(messages) {
    let csv = "";
    for (let i=0; i<messages.length; i++) {
        let message = messages[i];
        let body = JSON.parse(message.Body);
        let datetime = new Date(body.timestamp);
        // https://stackoverflow.com/questions/10645994/how-to-format-a-utc-date-as-a-yyyy-mm-dd-hhmmss-string-using-nodejs
        datetime = datetime.toISOString().replace(/T/, ' ').replace(/\..+/, '');
        csv += `"${body.username}", "${body.unicornId}", "${datetime}"\n`;
    }
    return csv;
}

function writeToS3(csv, filename) {
    const s3 = new AWS.S3();
    const params = {
        Bucket: process.env.S3_BUCKET,
        Key: `${filename}`,
        Body: csv
    };
    return s3.upload(params).promise();
}

function notifySNS(message) {
    var sns = new AWS.SNS();
    const params = {
        TopicArn: process.env.SNS_TOPIC,
        Message: JSON.stringify(message)
    };
    return sns.publish(params).promise();
}
