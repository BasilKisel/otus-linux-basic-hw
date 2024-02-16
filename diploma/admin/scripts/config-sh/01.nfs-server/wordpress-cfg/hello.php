<!DOCTYPE html>
<html lang="en">
    <head><title>Quick check page</title></head>
    <body>
Host name: <?php echo getHostName(); ?>
<br/>
Host IP: <?php echo getHostByName(getHostName()); ?>
    </body>
</html>
