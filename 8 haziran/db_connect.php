    <?php
$host = "localhost";
$user = "root";
$pass = ""; 
$db = "kahve_dukkani_yildiz_puan";

$conn = mysqli_connect($host, $user, $pass, $db);

if (!$conn) {
    die("Veritabanı bağlantısı başarısız: " . mysqli_connect_error());
}

mysqli_set_charset($conn, "utf8");
?>