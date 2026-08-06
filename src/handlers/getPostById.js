import {
  getPostById,
} from '../services/dynamoService.js';

import { response } from '../utils/response.js';

export const handler = async (event) => {
  try {

    const id =
      event.pathParameters.id;

    const item =
      await getPostById(id);

    if (!item) {
      return response(404, {
        success: false,
        message: 'Post not found',
      });
    }

    return response(200, {
      success: true,
      data: item,
    });

  } catch (error) {

    return response(500, {
      success: false,
      error: error.message,
    });
  }
};