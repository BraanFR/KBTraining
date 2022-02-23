var React = require("react")
var createReactClass = require('create-react-class')
var remoteProps = require('../props.js')

var Orders = createReactClass({
    statics: {
      remoteProps: [remoteProps.orders]
    },
    render(){
      return <JSXZ in="orders" sel=".layout-container">
          <Z sel=".orders-container">
          </Z>
        </JSXZ>
    }
})

module.exports = Orders