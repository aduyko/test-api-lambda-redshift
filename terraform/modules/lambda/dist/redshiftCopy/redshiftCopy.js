const pg  = require('pg');

exports.handler = async (event, context, callback) => {
    console.log(event);
    const message = JSON.parse(event.Records[0].Sns.Message);
    console.log(message);
    const filename = message.filename;

    const pgClient = new pg.Client();
    await pgClient.connect();
    console.log("Created redshift connection");

    const s3_path = `s3://${process.env.S3_BUCKET}/${filename}`;
    const text = `COPY ${process.env.PGSCHEMA}.rides(username,unicorn_id,request_time) FROM '${s3_path}' IAM_ROLE '${process.env.IAM_ROLE}' CSV;`;

    try {
        query = await pgClient.query(text);
        await pgClient.end();
        console.log(`Successfully loaded ${filename} to redshift`);
        context.succeed(`Successfully loaded ${filename} to redshift`);
    } catch(err) {
        console.error(err);
        context.fail(err);
    }
};
