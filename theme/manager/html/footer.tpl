<footer class="footer">
    <div class="float-left">
    © {''|date:'Y'} <strong style="color:#000000">ЭКО</strong><strong style="color:#83d462">ЗАЙМ</strong>
    </div>
    <div class="float-right">
    
    {if $manager->offline_point_id}
        {$offline_points[$manager->offline_point_id]->city}
        {$offline_points[$manager->offline_point_id]->address}
    {/if}
    </div>
</footer>