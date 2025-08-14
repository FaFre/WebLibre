/* eslint-disable */
const path = require('path')
const TsconfigPathsPlugin = require('tsconfig-paths-webpack-plugin')
const CopyPlugin = require('copy-webpack-plugin')

module.exports = {
  entry: {
    background: './src/background/index.ts',
  },
  devtool: 'source-map',
  mode: 'development',
  performance: {
    hints: false,
  },
  node: false,
  optimization: {
    minimize: false,
    moduleIds: 'named',
    chunkIds: 'named',
    concatenateModules: false,
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.module.scss'],
    plugins: [new TsconfigPathsPlugin()],
  },
  output: {
    filename: '[name]/index.js',
    path: path.resolve(__dirname, 'dist'),
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        loader: 'ts-loader',
        exclude: /node_modules/,
      },
    ]
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        'README.md',
        'LICENSE',
        'src/manifest.json',
      ],
    }),
  ],
  devServer: {
    hot: false,
    inline: false,
    writeToDisk: true,
  },
}
