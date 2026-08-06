import {
  DynamoDBClient,
} from '@aws-sdk/client-dynamodb';

import {
  DynamoDBDocumentClient,
  PutCommand,
  ScanCommand,
  GetCommand,
  UpdateCommand,
  DeleteCommand,
} from '@aws-sdk/lib-dynamodb';

import { ENV } from '../config/env.js';

const client = new DynamoDBClient({
  region: ENV.APP_AWS_REGION,
});

const dynamo =
  DynamoDBDocumentClient.from(client);

export const createPost = async (item) => {
  await dynamo.send(
    new PutCommand({
      TableName: ENV.TABLE_NAME,
      Item: item,
    })
  );

  return item;
};

export const getPosts = async () => {
  const response = await dynamo.send(
    new ScanCommand({
      TableName: ENV.TABLE_NAME,
    })
  );

  return response.Items || [];
};

export const getPostById = async (id) => {
  const response = await dynamo.send(
    new GetCommand({
      TableName: ENV.TABLE_NAME,
      Key: { id },
    })
  );

  return response.Item;
};

export const updatePost = async (
  id,
  post,
  author
) => {
  const response = await dynamo.send(
    new UpdateCommand({
      TableName: ENV.TABLE_NAME,
      Key: { id },

      UpdateExpression:
        'SET post = :post, author = :author',

      ExpressionAttributeValues: {
        ':post': post,
        ':author': author,
      },

      ReturnValues: 'ALL_NEW',
    })
  );

  return response.Attributes;
};

export const deletePost = async (id) => {
  await dynamo.send(
    new DeleteCommand({
      TableName: ENV.TABLE_NAME,
      Key: { id },
    })
  );
};