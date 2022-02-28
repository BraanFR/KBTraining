var React = require("react")
var createReactClass = require('create-react-class')

var Layout = createReactClass({
    render(){
      return <JSXZ in="orders" sel=".layout-container">
          <Z sel=".layout-wrapper">
            <this.props.Child {...this.props}/>
          </Z>
        </JSXZ>
    }
})

module.exports = Layout