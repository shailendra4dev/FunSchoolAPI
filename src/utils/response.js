export const response = (
  statusCode,
  data
) => ({
  statusCode,

  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "http://localhost:3000, https://d396lh7c4lwt6i.cloudfront.net",
    "Access-Control-Allow-Headers": "Content-Type,Authorization",
    "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
  },

  body: JSON.stringify(data),
});