<?php

interface ApiInterface
{
    public static function getRequest($request);
    public static function curl($params);
    public static function response($response);
    public static function toLogs($log);
}