const path = require('path');

module.exports = {
    mode: 'development',
    entry: './src/main.js',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'dist'),
        publicPath: '/dist/'
    },
    module: {
        rules: [
            {
                test: /\.m?js$/,
                exclude: /(node_modules|bower_components)/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env']
                    }
                }
            },
            {
                test: /\.glsl$/,
                use: 'raw-loader'
            }
        ]
    },
    devServer: {
        static: {
            directory: path.join(__dirname, '/'),
        },
        port: 3100,
        open: true,
        hot: true
    },
};
