const path = require("path");
const webpack = require("webpack");
const merge = require("webpack-merge");

const ClosurePlugin = require('closure-webpack-plugin');
const CopyWebpackPlugin = require("copy-webpack-plugin");
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
// to add a service worker
const workboxPlugin = require('workbox-webpack-plugin');
// to extract the css as a separate file
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

var MODE =
    process.env.npm_lifecycle_event === "build" ? "production" : "development";
var withDebug = !process.env["npm_config_nodebug"] && MODE == "development";
console.log(process.env.npm_lifecycle_event);
console.log('\x1b[36m%s\x1b[0m', `** elm-webpack-starter: mode "${MODE}", withDebug: ${withDebug}\n`);

var common = {
    mode: MODE,
    entry: "./src/index.js",
    output: {
        path: path.resolve(__dirname, '../priv/static'),
        publicPath: MODE == "production" ? "/" : "http://localhost:3000/",
        // FIXME webpack -p automatically adds hash when building for production
        //filename: MODE == "production" ? "[name]-[hash].js" : "index.js"
        filename: 'app.js'
    },
    plugins: [],
    resolve: {
        modules: [path.join(__dirname, "src"), "node_modules"],
        extensions: [".js", ".elm", ".scss", ".png"]
    },
    module: {
        rules: [
        ]
    }
};

if (MODE === "development") {
    module.exports = merge(common, {
        plugins: [
            // Suggested for hot-loading
            new webpack.NamedModulesPlugin(),
            // Prevents compilation errors causing the hot loader to lose state
            new webpack.NoEmitOnErrorsPlugin()
        ],
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        { loader: "elm-hot-webpack-loader" },
                        {
                            loader: "elm-webpack-loader",
                            options: {
                                pathToElm: 'node_modules/.bin/elm',
                                // add Elm's debug overlay to output
                                debug: withDebug,
                                //
                                forceWatch: true
                            }
                        }
                    ]
                },


                {
                    test: /\.js$/,
                    exclude: /node_modules/,
                    use: {
                        loader: "babel-loader"
                    }
                },
                {
                    test: /\.scss$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    // see https://github.com/webpack-contrib/css-loader#url
                    loaders: ["style-loader", "css-loader?url=false", "sass-loader"]
                },
                {
                    test: /\.css$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loaders: ["style-loader", "css-loader?url=false"]
                },
                {
                    test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loader: "url-loader",
                    options: {
                        limit: 10000,
                        mimetype: "application/font-woff"
                    }
                },
                {
                    test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loader: "file-loader"
                },
                {
                    test: /\.(jpe?g|png|gif|svg)$/i,
                    exclude: [/elm-stuff/, /node_modules/],
                    loader: "file-loader"
                }

            ]
        },
        devServer: {
            inline: true,
            stats: "errors-only",
            contentBase: path.join(__dirname, "src/assets"),
            historyApiFallback: true,
            headers: {
                'Access-Control-Allow-Origin': '*'
            }
        }
    });
}
if (MODE === "production") {
    module.exports = merge(common, {
        optimization: {
            minimizer: [
                // new ClosurePlugin({mode: 'STANDARD', platform: 'native'}, {
                //   // compiler flags here
                //   //
                //   // for debugging help, try these:
                //   //
                //   // formatting: 'PRETTY_PRINT',
                //   // debug: true
                //   // renaming: false
                // })
            ]
        },
        plugins: [
            // Delete everything from output-path (/dist) and report to user
            new CleanWebpackPlugin({
                root: __dirname,
                exclude: [],
                verbose: true,
                dry: false
            }),
            // Copy static assets
            new CopyWebpackPlugin([
                {
                    from: "public"
                }
            ]),
            new MiniCssExtractPlugin({
                // Options similar to the same options in webpackOptions.output
                // both options are optional
                filename: "app.css"
            }),
            new workboxPlugin.GenerateSW({
                swDest: './service-worker.js',
                skipWaiting: true,
                clientsClaim: true,
            })
        ],
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: {
                        loader: "elm-webpack-loader",
                        options: {
                            optimize: true,
                            pathToElm: 'node_modules/.bin/elm',
                        }
                    }
                },
                {
                    test: /\.css$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loaders: [
                        MiniCssExtractPlugin.loader,
                        "css-loader?url=false"
                    ]
                },
                {
                    test: /\.scss$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loaders: [
                        MiniCssExtractPlugin.loader,
                        "css-loader?url=false",
                        "sass-loader"
                    ]
                }
            ]
        }
    });
}
