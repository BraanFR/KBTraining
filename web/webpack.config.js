module.exports = {
  entry: './component/app.js',
  output: { filename: 'bundle.js' },
  plugins: [],
  module: {
    rules: [
      {
        test: /.js?$/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              ["@babel/preset-env", { "targets": "defaults" }], "@babel/preset-react"]
          }
        },
        exclude: /node_modules/
      }
    ]
  },
  
  mode: 'production',
}