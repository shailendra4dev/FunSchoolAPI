import {
  deletePost,
} from '../services/dynamoService.js';

import { response } from '../utils/response.js';

export const handler = async (event) => {
  try {

    const id =
      event.pathParameters.id;

    await deletePost(id);

    return response(200, {
      success: true,
      message: 'Post deleted',
    });

  } catch (error) {

    return response(500, {
      success: false,
      error: error.message,
    });
  }
};