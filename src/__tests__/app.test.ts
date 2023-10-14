import supertest from 'supertest';
import App from '../app';

function isWithinSameSecond(timestamp: number) {
  const now = Math.floor(Date.now() / 1000);
  const targetTime = Math.floor(timestamp / 1000);
  return now === targetTime;
}

const instance = supertest(new App().instance());
describe('given the index route', () => {
  it('should return 200', async () => {
    const { statusCode, body } = await instance.get('/');

    expect(statusCode).toBe(200);
    expect(body.message).toEqual('WELCOME');
  });
});
describe('given a the automate route', () => {
  it('should return 200, Automate all the things and a valid timestamp within the same second', async () => {
    const { statusCode, body } = await instance.get('/automate');

    expect(statusCode).toBe(200);
    expect(body.message).toBe('Automate all the things!');
    expect(isWithinSameSecond(body.timestamp)).toBe(true);
  });
});
describe('given a random route', () => {
  it('should throw a not found error', async () => {
    const { statusCode, body } = await instance.get('/random');

    expect(statusCode).toBe(404);
  });
});
