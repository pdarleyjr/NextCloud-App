<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php p($template->getHeaderTitle()); ?></title>
    <?php foreach($template->getHeaders() as $header): ?>
        <?php
        if(is_array($header)) {
            echo '<meta';
            foreach ($header as $key => $value) {
                echo ' ' . $key . '="' . $value . '"';
            }
            echo '>';
        } else {
            echo $header;
        }
        ?>
    <?php endforeach; ?>
</head>
<body>
    <div class="content">
        <?php print_unescaped($content); ?>
    </div>
</body>
</html>