<style>
img { 
  padding: 20px; 
  height: 400px;
  width: auto;
}
</style>

<script>
// make an HTML element and button that will show <img src="http://edgecats.net/"/> when you click it

document.getElementById('catButton').onclick = function showSomeCats() {
  document.getElementById('catBox').innerHTML = ('<img src="http://edgecats.net/' + Math.random() + '"/>');
};
</script>

<!-- element for onclick event -->
<button id="catButton">Cat Generator</button>
<!-- element destination for cat gifs -->
<div id="catBox"></div>
