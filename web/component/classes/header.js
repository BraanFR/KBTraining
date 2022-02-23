var React = require("react")
var createReactClass = require('create-react-class')

var Header = createReactClass({
    render(){
      return <JSXZ in="orders" sel=".layout-container">
          <Z sel=".header-container">
            <this.props.Child {...this.props}/>
          </Z>
        </JSXZ>
    }
})

module.exports = Header