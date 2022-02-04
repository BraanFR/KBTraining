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
              ["@babel/preset-env", { "targets": "defaults" }],
              "@babel/preset-react",
              ["@kbrw/babel-preset-jsxz", { dir: 'webflow' }] 
            ]
          }
        },
        exclude: /node_modules/
      }
    ]
  },
  
  mode: 'production',
}