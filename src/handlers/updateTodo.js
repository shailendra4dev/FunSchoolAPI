import {
  updateTodo,
} from '../services/dynamoService.js';

import { response } from '../utils/response.js';

export const handler = async (event) => {
  try {

    const id =
      event.pathParameters.id;

    const body =
      JSON.parse(event.body);

    const updated =
      await updateTodo(
        id,
        body.title,
        body.completed
      );

    return response(200, {
      success: true,
      data: updated,
    });

  } catch (error) {

    return response(500, {
      success: false,
      error: error.message,
    });
  }
};