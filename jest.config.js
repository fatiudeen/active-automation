module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',

  verbose: true,
  clearMocks: true,
  moduleDirectories: ['node_modules', '<rootDir>/src'],
  modulePathIgnorePatterns: ['./dist', './node_modules'],
};
