import express, { Application } from 'express';
import cors from 'cors';

class App {
  private app: Application;

  constructor() {
    this.app = express();

    this.initMiddlewares();
    this.initRoutes();
    this.initErrorHandlers();
  }

  private initRoutes() {
    this.app.get('/', (req, res) => {
      res.status(200).json({ message: 'WELCOME' });
    });
    this.app.get('/automate', (req, res) => {
      res.status(200).json({
        message: 'Automate all the things!',
        timestamp: Date.now(),
      });
    });
  }
  private initMiddlewares() {
    this.app.use(
      cors({
        origin: ['*'],
      }),
    );
  }

  private initErrorHandlers() {
    this.app.use('*', (req, res) => {
      res.status(404).json({ msg: 'Route not found' });
    });
  }

  public listen(port: number) {
    this.app.listen(port, () => {
      console.info(`running on port ${port}`);
    });
  }

  public instance() {
    return this.app;
  }
}

export default App;
