var React = require("react")
var createReactClass = require('create-react-class')

var Layout = createReactClass({
    render(){
      return <JSXZ in="orders" sel=".main-container">
          <Z sel=".layout-container">
            <this.props.Child {...this.props}/>
          </Z>
        </JSXZ>
    }
})

module.exports = Layout