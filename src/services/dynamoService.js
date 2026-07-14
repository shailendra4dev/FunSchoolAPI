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
  region: ENV.AWS_REGION,
});

const dynamo =
  DynamoDBDocumentClient.from(client);

export const createTodo = async (item) => {
  await dynamo.send(
    new PutCommand({
      TableName: ENV.TABLE_NAME,
      Item: item,
    })
  );

  return item;
};

export const getTodos = async () => {
  const response = await dynamo.send(
    new ScanCommand({
      TableName: ENV.TABLE_NAME,
    })
  );

  return response.Items || [];
};

export const getTodoById = async (id) => {
  const response = await dynamo.send(
    new GetCommand({
      TableName: ENV.TABLE_NAME,
      Key: { id },
    })
  );

  return response.Item;
};

export const updateTodo = async (
  id,
  title,
  completed
) => {
  const response = await dynamo.send(
    new UpdateCommand({
      TableName: ENV.TABLE_NAME,
      Key: { id },

      UpdateExpression:
        'SET title = :title, completed = :completed',

      ExpressionAttributeValues: {
        ':title': title,
        ':completed': completed,
      },

      ReturnValues: 'ALL_NEW',
    })
  );

  return response.Attributes;
};

export const deleteTodo = async (id) => {
  await dynamo.send(
    new DeleteCommand({
      TableName: ENV.TABLE_NAME,
      Key: { id },
    })
  );
};