<?php

use PhpOffice\PhpSpreadsheet\IOFactory;

error_reporting(-1);
ini_set('display_errors', 'On');

class TestController extends Controller
{
    public function fetch()
    {


        
        exit;
    }

    // Сжать изображение 
    public function compressImage($source, $destination, $quality) {

        $info = getimagesize($source);

        if ($info['mime'] == 'image/jpeg') 
        $image = imagecreatefromjpeg($source);

        elseif ($info['mime'] == 'image / gif') 
        $image = imagecreatefromgif($source);

        elseif ($info['mime'] == 'image/png') 
        $image = imagecreatefrompng($source);

        imagejpeg($image, $destination, $quality);

    }

    public function send_message($token, $chat_id, $text)
	{
		$getQuery = array(
            "chat_id" 	=> $chat_id,
            "text"  	=> $text,
            "parse_mode" => "html",
        );
        $ch = curl_init("https://api.telegram.org/bot". $token ."/sendMessage?" . http_build_query($getQuery));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_HEADER, false);

        $resultQuery = curl_exec($ch);
        curl_close($ch);

        echo $resultQuery;
    }

    public function run_scoring($scoring_id)
    {
        $scoring = $this->scorings->get_scoring($scoring_id);
        $order = $this->orders->get_order((int)$scoring->order_id);

        $person =
            [
                'personLastName' => $order->lastname,
                'personFirstName' => $order->firstname,
                'phone' => preg_replace('/[^0-9]/', '', $order->phone_mobile),
                'personBirthDate' => date('d.m.Y', strtotime($order->birth))
            ];

        if (!empty($order->patronymic))
            $person['personMidName'] = $order->patronymic;

        $score = $this->IdxApi->search($person);

        if (empty($score)) {

            $update =
                [
                    'status' => 'error',
                    'body' => '',
                    'success' => 0,
                    'string_result' => 'Ошибка запроса'
                ];

            $this->scorings->update_scoring($scoring_id, $update);
            $this->logging($person, $score);
            return $update;
        }

        if ($score['operationResult'] == 'fail') {
            $update =
                [
                    'status' => 'completed',
                    'body' => '',
                    'success' => 0,
                    'string_result' => 'Клиент не найден в списке'
                ];

            $this->scorings->update_scoring($scoring_id, $update);
            $this->logging($person, $score);
            return $update;
        }

        $update =
            [
                'status' => 'completed',
                'body' => $score['validationScorePhone'],
                'success' => 1,
                'string_result' => 'Пользователь найден: ' . $this->IdxApi->result[$score['validationScorePhone']]
            ];

        $this->scorings->update_scoring($scoring_id, $update);
        return $this->logging($person, $score);
    }

    private function logging($request, $response, $filename = 'idxLog.txt')
    {
        echo 1;


        $log_filename = $this->config->root_dir.'logs/'. $filename;

        if (date('d', filemtime($log_filename)) != date('d')) {
            $archive_filename = $this->config->root_dir.'logs/' . 'archive/' . date('ymd', filemtime($log_filename)) . '.' . $filename;
            rename($log_filename, $archive_filename);
            file_put_contents($log_filename, "\xEF\xBB\xBF");
        }


        $str = PHP_EOL . '===================================================================' . PHP_EOL;
        $str .= date('d.m.Y H:i:s') . PHP_EOL;
        $str .= var_export($request, true) . PHP_EOL;
        $str .= var_export($response, true) . PHP_EOL;
        $str .= 'END' . PHP_EOL;

        file_put_contents($this->config->root_dir.'logs/' . $filename, $str, FILE_APPEND);

        return 1;
    }

    private function restrDocs()
    {
        $contract = ContractsORM::find(2141);
        $user = UsersORM::find(20473);

        $paymentSchedules = PaymentsSchedulesORM::find(28);
        $paymentSchedules = json_decode($paymentSchedules->payment_schedules, true);

        $schedule = new stdClass();
        $schedule->order_id = 22984;
        $schedule->user_id = 20473;
        $schedule->contract_id = 2141;
        $schedule->init_od = $contract->loan_body_summ;
        $schedule->init_prc = $contract->loan_percents_summ;
        $schedule->init_peni = $contract->loan_peni_summ;
        $schedule->actual = 1;
        $schedule->payment_schedules = json_encode($paymentSchedules);

        $params = [
            'contract' => $contract,
            'user' => $user,
            'schedules' => $schedule
        ];

        var_dump(json_encode($params));
        exit;
    }
}