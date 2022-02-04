
const { displayAlert } = require('../script')

const btn = <button onClick={ () => displayAlert() }>Click Me</button>
ReactDOM.render(
    btn,
    document.getElementById('root')
);



var createReactClass = require('create-react-class')

var Page = createReactClass({
  render(){
    return <JSXZ in="template" sel=".container">
      <Z sel=".item">Burgers</Z>,
      <Z sel=".price">50</Z>
    </JSXZ>
  }
})

ReactDOM.render(
  <Page/>,
  document.getElementById('burger')
)
