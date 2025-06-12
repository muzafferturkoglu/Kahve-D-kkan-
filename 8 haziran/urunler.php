<?php
require_once 'db_connect.php';

// Ürün Ekleme
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['urun_ekle'])) {
    $id = mysqli_real_escape_string($conn, $_POST['urun_id']);
    $ad = mysqli_real_escape_string($conn, $_POST['urun_ad']);
    $kategori = mysqli_real_escape_string($conn, $_POST['urun_kategori']);
    $fiyat = mysqli_real_escape_string($conn, $_POST['urun_fiyat']);
    $stok = mysqli_real_escape_string($conn, $_POST['urun_stok']);
    $birim = mysqli_real_escape_string($conn, $_POST['urun_birim']);
    $aciklama = mysqli_real_escape_string($conn, $_POST['urun_aciklama']);

    mysqli_query($conn, "CALL kd_UrunEkle('$id', '$ad', '$kategori', '$fiyat', '$stok', '$birim', '$aciklama')");
    header("Location: urunler.php");
    exit();
}

// Ürün Silme
if (isset($_GET['delete_id'])) {
    $id_to_delete = mysqli_real_escape_string($conn, $_GET['delete_id']);
    mysqli_query($conn, "CALL kd_UrunSil('$id_to_delete')");
    header("Location: urunler.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Ürün Yönetimi</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <nav><a href="index.php">Ana Sayfa</a></nav>
    <h1>Ürün Yönetimi</h1>

    <form action="urunler.php" method="POST">
        <h2>Yeni Ürün Ekle</h2>
        <input type="text" name="urun_id" placeholder="Ürün ID (örn: PROD-<?= rand(100,999) ?>)" required>
        <input type="text" name="urun_ad" placeholder="Ürün Adı" required>
        <input type="text" name="urun_kategori" placeholder="Kategori (örn: Sıcak İçecek)" required>
        <input type="number" step="0.01" name="urun_fiyat" placeholder="Birim Fiyat" required>
        <input type="number" name="urun_stok" placeholder="Stok Miktarı" required>
        <input type="text" name="urun_birim" placeholder="Birim (örn: Bardak, Adet)" required>
        <textarea name="urun_aciklama" placeholder="Açıklama"></textarea>
        <button type="submit" name="urun_ekle">Ekle</button>
    </form>

    <h2>Mevcut Ürünler</h2>
    <table>
        <thead>
            <tr><th>ID</th><th>Adı</th><th>Kategori</th><th>Fiyat</th><th>Stok</th><th>Birim</th><th>Puan</th><th>İşlemler</th></tr>
        </thead>
        <tbody>
            <?php
            $result = mysqli_query($conn, "CALL kd_UrunlerHepsi()");
            while ($row = mysqli_fetch_assoc($result)) {
                echo "<tr>";
                echo "<td>" . htmlspecialchars($row['ID']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Adı']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Kategori']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Fiyat']) . " ₺</td>";
                echo "<td>" . htmlspecialchars($row['Stok']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Birim']) . "</td>";
                echo "<td>" . number_format($row['OrtalamaPuan'], 2) . "</td>";
                echo "<td><a href='urunler.php?delete_id=" . urlencode($row['ID']) . "' onclick='return confirm(\"Emin misiniz?\")'>Sil</a></td>";
                echo "</tr>";
            }
            mysqli_free_result($result);
            mysqli_next_result($conn);
            ?>
        </tbody>
    </table>
</div>
</body>
</html>