export const response = (
  statusCode,
  data
) => ({
  statusCode,

  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  },

  body: JSON.stringify(data),
});