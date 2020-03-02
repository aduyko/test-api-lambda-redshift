const randomBytes = require('crypto').randomBytes;
const AWS = require('aws-sdk');

exports.handler = (event, context) => {
    let data;
    let res = getMessages("aa", "aa", {Id:1}).promise();
    res.then(function(data) {
        console.log("Got Messages:");
        console.log(data);
        csv = createCsv(data);

        res = writeToS3(csv).promise();
        res.then(function(data) {
            context.succeed(`File uploaded to s3 successfully at ${data.Location}`);
        }).catch((err) => {
            console.error(err);
            context.fail(err);
        });
    }).catch((err) => {
        console.error(err);
        context.fail(err);
    });

    

};

function getMessages(rideId, username, unicorn) {
  // SQS code here
  const sqs = new AWS.SQS({apiVersion: '2012-11-05'});
  let params = {
    QueueUrl: `${process.env.SQS_QUEUE_URL}`,
    MaxNumberOfMessages: process.env.SQS_BATCH_SIZE,
    WaitTimeSeconds: 5
  };

  return sqs.receiveMessage(params);
}

function createCsv(messages) {
    return messages;
}

function writeToS3(csv) {
    const s3 = new AWS.S3();
    //read csv? use csv stream?
 const params = {
   Bucket: 'aduyko-serverless-test-redshift', // pass your bucket name
   Key: 'test.csv', // file will be saved as testBucket/contacts.csv
   Body: JSON.stringify(csv, null, 2)
 };
 return s3.upload(params);
}
