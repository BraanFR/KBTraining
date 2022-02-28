var path = require('path')
var MiniCssExtractPlugin = require('mini-css-extract-plugin')
var CssMinimizerPlugin = require('css-minimizer-webpack-plugin')


module.exports = {
  entry: './component/app.js',
  output: {
    path: path.join(__dirname, '../priv/static' ),
    filename: 'bundle.js',
  },
  //This will bundle all our .css file inside styles.css
  // optimization: {
  //   splitChunks: {cacheGroups: {styles: {name: 'styles', test: /\.css$/ , chunks: 'all', enforce: true}}},
  //   minimizer: [`...`, new CssMinimizerPlugin()]
  // },
  devtool: "inline-source-map",
  plugins: [new MiniCssExtractPlugin({insert: "", filename: "[name].css"})],
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
      },
      {
        test: /\.(css)$/,
        use: [{loader: MiniCssExtractPlugin.loader}, { loader: "css-loader" }]
      }
    ]
  },
  
  mode: 'production',
}