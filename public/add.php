<?php

// Add recipe if one was submitted
if (count($_POST) > 0) {
}
?>
<html>
<head>
  <title>Recipe Search</title>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css"></head>
</head>
<body>
<div class="container">
<h1>Add Recipe</h1>
<form method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
    <label for="name">Name:</label> <input name="name"/>
    <label for="description">Description:</label>
</form>
</div>
</body>
</html>
