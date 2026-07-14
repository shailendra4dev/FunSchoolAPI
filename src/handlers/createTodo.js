import { v4 as uuid } from 'uuid';

import {
  createTodo,
} from '../services/dynamoService.js';

import { response } from '../utils/response.js';

export const handler = async (event) => {
  try {

    const body = JSON.parse(event.body);

    const item = {
      id: uuid(),
      title: body.title,
      completed: false,
      createdAt: new Date().toISOString(),
    };

    const savedItem =
      await createTodo(item);

    return response(201, {
      success: true,
      data: savedItem,
    });

  } catch (error) {

    return response(500, {
      success: false,
      error: error.message,
    });
  }
};