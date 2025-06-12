<?php
require_once 'db_connect.php';

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['musteri_ekle'])) {
    $id = mysqli_real_escape_string($conn, $_POST['musteri_id']);
    $ad = mysqli_real_escape_string($conn, $_POST['musteri_ad']);
    $soyad = mysqli_real_escape_string($conn, $_POST['musteri_soyad']);
    $tel = mysqli_real_escape_string($conn, $_POST['musteri_tel']);
    $email = mysqli_real_escape_string($conn, $_POST['musteri_email']);

    mysqli_query($conn, "CALL kd_MusteriEkle('$id', '$ad', '$soyad', '$tel', '$email', NULL)");
    header("Location: musteriler.php");
    exit();
}


if (isset($_GET['delete_id'])) {
    $id_to_delete = mysqli_real_escape_string($conn, $_GET['delete_id']);
    mysqli_query($conn, "CALL kd_MusteriSil('$id_to_delete')");
    header("Location: musteriler.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Müşteri Yönetimi</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <nav><a href="index.php">Ana Sayfa</a></nav>
    <h1>Müşteri Yönetimi</h1>

    <form action="musteriler.php" method="POST">
        <h2>Yeni Müşteri Ekle</h2>
        <input type="text" name="musteri_id" placeholder="Müşteri ID (örn: CUST-<?= rand(100,999) ?>)" required>
        <input type="text" name="musteri_ad" placeholder="Ad" required>
        <input type="text" name="musteri_soyad" placeholder="Soyad" required>
        <input type="tel" name="musteri_tel" placeholder="Telefon" required>
        <input type="email" name="musteri_email" placeholder="Email" required>
        <button type="submit" name="musteri_ekle">Ekle</button>
    </form>

    <h2>Mevcut Müşteriler</h2>
    <table>
        <thead>
            <tr><th>ID</th><th>Adı Soyadı</th><th>Email</th><th>Telefon</th><th>İşlemler</th></tr>
        </thead>
        <tbody>
            <?php
            $result = mysqli_query($conn, "CALL kd_MusterilerHepsi()");
            while ($row = mysqli_fetch_assoc($result)) {
                echo "<tr>";
                echo "<td>" . htmlspecialchars($row['ID']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Adı']) . " " . htmlspecialchars($row['Soyadı']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Mail']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Telefon']) . "</td>";
                echo "<td><a href='musteriler.php?delete_id=" . urlencode($row['ID']) . "' onclick='return confirm(\"Emin misiniz?\")'>Sil</a></td>";
                echo "</tr>";
            }
            mysqli_free_result($result);
            mysqli_next_result($conn); // Birden fazla sorgu için sonraki sonuca geç
            ?>
        </tbody>
    </table>
</div>
</body>
</html>