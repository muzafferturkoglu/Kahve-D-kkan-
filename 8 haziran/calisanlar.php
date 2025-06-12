<?php
// calisanlar.php

require_once 'db_connect.php';

// Çalışan Ekleme İşlemi
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['calisan_ekle'])) {
    $id = mysqli_real_escape_string($conn, $_POST['calisan_id']);
    $ad = mysqli_real_escape_string($conn, $_POST['calisan_ad']);
    $soyad = mysqli_real_escape_string($conn, $_POST['calisan_soyad']);
    $pozisyon = mysqli_real_escape_string($conn, $_POST['pozisyon']);
    // Formdan gelen tarih YYYY-MM-DD formatındadır. SQL DATETIME formatına uygun hale getirelim.
    $ise_baslama_tarihi = mysqli_real_escape_string($conn, $_POST['ise_baslama_tarihi']) . ' 00:00:00';
    // AktifMi değeri 1 (true) veya 0 (false) olarak alınır.
    $aktif_mi = (int)$_POST['aktif_mi'];

    // Belgedeki saklı yordamı çağırıyoruz
    $sql = "CALL kd_CalisanEkle('$id', '$ad', '$soyad', '$pozisyon', '$ise_baslama_tarihi', $aktif_mi)";
    
    mysqli_query($conn, $sql);
    header("Location: calisanlar.php");
    exit();
}

// Çalışan Silme İşlemi
if (isset($_GET['delete_id'])) {
    $id_to_delete = mysqli_real_escape_string($conn, $_GET['delete_id']);
    // Belgedeki saklı yordamı çağırıyoruz
    mysqli_query($conn, "CALL kd_CalisanSil('$id_to_delete')");
    header("Location: calisanlar.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Çalışan Yönetimi</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <nav><a href="index.php">Ana Sayfa</a></nav>
    <h1>Çalışan Yönetimi</h1>

    <form action="calisanlar.php" method="POST">
        <h2>Yeni Çalışan Ekle</h2>
        <input type="text" name="calisan_id" placeholder="Çalışan ID (örn: EMP-<?= rand(100,999) ?>)" required>
        <input type="text" name="calisan_ad" placeholder="Ad" required>
        <input type="text" name="calisan_soyad" placeholder="Soyad" required>
        <input type="text" name="pozisyon" placeholder="Pozisyon (örn: Barista)" required>
        <label for="ise_baslama_tarihi">İşe Başlama Tarihi:</label>
        <input type="date" name="ise_baslama_tarihi" required>
        <label for="aktif_mi">Durumu:</label>
        <select name="aktif_mi" required>
            <option value="1">Aktif</option>
            <option value="0">Pasif</option>
        </select>
        <button type="submit" name="calisan_ekle">Ekle</button>
    </form>

    <h2>Mevcut Çalışanlar</h2>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Adı Soyadı</th>
                <th>Pozisyon</th>
                <th>İşe Başlama</th>
                <th>Durum</th>
                <th>İşlemler</th>
            </tr>
        </thead>
        <tbody>
            <?php
            // Belgedeki saklı yordamı çağırıyoruz
            $result = mysqli_query($conn, "CALL kd_CalisanlarHepsi()");
            while ($row = mysqli_fetch_assoc($result)) {
                // Aktif/Pasif durumunu metne çeviriyoruz
                
                // **** DÜZELTİLEN SATIR (SONA NOKTALI VİRGÜL EKLENDİ) ****
                $durum = $row['AktifMi'] ? '<span style="color:green;">Aktif</span>' : '<span style="color:red;">Pasif</span>';
                
                echo "<tr>";
                echo "<td>" . htmlspecialchars($row['ID']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Adı']) . " " . htmlspecialchars($row['Soyadı']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Pozisyon']) . "</td>";
                echo "<td>" . htmlspecialchars(date('d-m-Y', strtotime($row['İşeBaşlama']))) . "</td>";
                echo "<td>" . $durum . "</td>";
                echo "<td><a href='calisanlar.php?delete_id=" . urlencode($row['ID']) . "' onclick='return confirm(\"Bu çalışanı silmek istediğinize emin misiniz?\")'>Sil</a></td>";
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