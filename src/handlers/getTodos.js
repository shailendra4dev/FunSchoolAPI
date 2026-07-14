import {
  getTodos,
} from '../services/dynamoService.js';

import { response } from '../utils/response.js';

export const handler = async () => {
  try {

    const items = await getTodos();

    return response(200, {
      success: true,
      count: items.length,
      data: items,
    });

  } catch (error) {

    return response(500, {
      success: false,
      error: error.message,
    });
  }
};