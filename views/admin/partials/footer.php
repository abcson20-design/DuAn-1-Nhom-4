<?php
// views/admin/partials/footer.php
?>
    <!-- SweetAlert2 cho Admin -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        window.NEXVORA_BASE_URL = '<?= BASE_URL ?>';
        window.NEXVORA_IS_ADMIN = true;
        window.NEXVORA_CURRENT_USER_ID = null;
    </script>
    <!-- NEXVORA Real-time Engine cho Admin -->
    <script src="<?= BASE_URL ?>public/js/nexvora-realtime.js?v=<?= @filemtime(__DIR__ . '/../../../public/js/nexvora-realtime.js') ?: time() ?>"></script>
</body>
</html>
