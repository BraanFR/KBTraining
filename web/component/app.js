
const { displayAlert } = require('../script')

const btn = <button onClick={ () => displayAlert() }>Click Me</button>
ReactDOM.render(
    btn,
    document.getElementById('root')
);