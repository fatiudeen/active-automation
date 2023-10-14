import App from './app';

const app = new App();
const port = process.env.PORT || 5000;

app.listen(+port);
