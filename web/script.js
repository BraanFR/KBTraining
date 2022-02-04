export const displayAlert = () => {
    const element = <h1>Hey I was created from React!</h1>;
    
    ReactDOM.render(
        element,
        document.getElementById('root')
    );
}


// function displayAlert(){
//     const element = React.createElement(
//         'h1',
//         {className: 'greeting'},
//         'Hey I was created from React!'
//     );
    
//     ReactDOM.render(
//         element,
//         document.getElementById('root')
//     );
// }
