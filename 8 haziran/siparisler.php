<?php
require_once 'db_connect.php';
$error_msg = '';
$success_msg = '';

// Sipariş Ekleme
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['siparis_ekle'])) {
    $p_siparis_id = "ORD-" . uniqid();
    $p_musteri_id = mysqli_real_escape_string($conn, $_POST['musteri_id']);
    $p_urun_id = mysqli_real_escape_string($conn, $_POST['urun_id']);
    $p_calisan_id = mysqli_real_escape_string($conn, $_POST['calisan_id']);
    $p_miktar = (int)$_POST['miktar'];
    $p_odeme_id = "PAY-" . uniqid();
    $p_odeme_tur = mysqli_real_escape_string($conn, $_POST['odeme_tur']);
    $p_odeme_aciklama = "Sipariş anında ödeme";

    // kd_SiparisVeAnindaOdemeEkle yordamı stok kontrolü yapar ve hata fırlatabilir.
    $sql = "CALL kd_SiparisVeAnindaOdemeEkle('$p_siparis_id', '$p_musteri_id', '$p_urun_id', '$p_calisan_id', $p_miktar, '$p_odeme_id', '$p_odeme_tur', '$p_odeme_aciklama')";

    if (!mysqli_query($conn, $sql)) {
        // SQLSTATE '45000' ile fırlatılan hatayı yakala
        if(mysqli_errno($conn) == 1644){
             $error_msg = mysqli_error($conn);
        } else {
             $error_msg = "Bilinmeyen bir hata oluştu: " . mysqli_error($conn);
        }
    } else {
        $success_msg = "Sipariş ve ödeme başarıyla eklendi!";
    }
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Sipariş Yönetimi</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <nav><a href="index.php">Ana Sayfa</a></nav>
    <h1>Sipariş Yönetimi</h1>
    
    <?php
    if ($error_msg) echo "<p class='error-msg'>$error_msg</p>";
    if ($success_msg) echo "<p class='success-msg'>$success_msg</p>";
    ?>

    <form action="siparisler.php" method="POST">
        <h2>Yeni Sipariş ve Ödeme Ekle</h2>
        
        <label>Müşteri:</label>
        <select name="musteri_id" required>
            <?php
            $result = mysqli_query($conn, "CALL kd_MusterilerHepsi()");
            while($row = mysqli_fetch_assoc($result)) echo "<option value='{$row['ID']}'>{$row['Adı']} {$row['Soyadı']}</option>";
            mysqli_free_result($result); mysqli_next_result($conn);
            ?>
        </select>

        <label>Ürün:</label>
        <select name="urun_id" required>
             <?php
            $result = mysqli_query($conn, "CALL kd_UrunlerHepsi()");
            while($row = mysqli_fetch_assoc($result)) echo "<option value='{$row['ID']}'>{$row['Adı']} (Stok: {$row['Stok']})</option>";
            mysqli_free_result($result); mysqli_next_result($conn);
            ?>
        </select>

        <label>İşlemi Yapan Çalışan:</label>
        <select name="calisan_id" required>
            <?php
            $result = mysqli_query($conn, "CALL kd_CalisanlarHepsi()");
            while($row = mysqli_fetch_assoc($result)) echo "<option value='{$row['ID']}'>{$row['Adı']} {$row['Soyadı']}</option>";
            mysqli_free_result($result); mysqli_next_result($conn);
            ?>
        </select>
        
        <label>Miktar:</label>
        <input type="number" name="miktar" value="1" min="1" required>
        
        <label>Ödeme Türü:</label>
        <select name="odeme_tur" required>
            <option>Nakit</option>
            <option>Kredi Kartı</option>
            <option>Mobil Ödeme</option>
        </select>
        
        <button type="submit" name="siparis_ekle">Sipariş Oluştur</button>
    </form>

    <h2>Geçmiş Siparişler</h2>
    <table>
        <thead>
            <tr><th>Sipariş ID</th><th>Müşteri</th><th>Ürün</th><th>Tutar</th><th>Tarih</th></tr>
        </thead>
        <tbody>
            <?php
            $result = mysqli_query($conn, "CALL kd_SiparislerHepsi()");
            while ($row = mysqli_fetch_assoc($result)) {
                echo "<tr>";
                echo "<td>" . htmlspecialchars($row['siparis_id']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Musteri']) . "</td>";
                echo "<td>" . htmlspecialchars($row['Urun']) . "</td>";
                echo "<td>" . number_format($row['toplam_tutar'], 2) . " ₺</td>";
                echo "<td>" . htmlspecialchars($row['siparis_tarihi']) . "</td>";
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