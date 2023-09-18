<?php

class Insurances extends Core
{
    /*
    При выдаче зависит от суммы займа:
1)займ от 1 до 4999 рубл 
    - страховая премия 590
    - страховая сумма 30000 рублей 
2) займ от 5000 до 8999 
    - страховая премия 890 
    - страховая сумма 40000 рублей 
3)от 9000 и выше 
    - страховая премия  990 рублей 
    - страховая сумма 50000 рублей
 
Продление: 
страховка 499 
 
Закрытие: 
Страховка 400
    */
    public function get_insurance_cost($amount)
    {
        if ($amount <= 4999)
            return 590;
        elseif ($amount >= 5000 && $amount <= 8999)
            return 890;
        elseif ($amount >= 9000)
            return 990;
    }

    // public function get_insurance_cost($amount, $region='')
    // {
    //     $contract_operations = $this->ServicesCost->gets(array('region' => $region));
    //     if (isset($contract_operations[0]->insurance_cost)) {
    //         return (float)$contract_operations[0]->insurance_cost;
    //     }
    //     else {
    //         if ($amount <= 4999)
    //             return 590;
    //         elseif ($amount >= 5000 && $amount <= 8999)
    //             return 890;
    //         elseif ($amount >= 9000)
    //             return 990;
    //     }
    // }


    /**
     * Insurances::create_number()
     *
     * 18-значная нумерация 200H3NZI163ХХХХХХХ
     * Где,
     * 20 – год выпуска полиса
     * 0H3 – код подразделения выпустившего полис (не меняется)
     * NZI – код продукта (не меняется)
     * 163 – код партнера (не меняется)
     * ХХХХХХХ – номер полиса страхования
     *
     * @param mixed $id
     * @return string
     */
    public function create_number($id)
    {
        $number = '';
        $number .= date('y'); // год выпуска полиса
        $number .= '0H3'; // код подразделения выпустившего полис (не меняется)
        $number .= 'NZI'; // код продукта (не меняется)
        $number .= '383'; // код партнера (не меняется)

        $polis_number = str_pad($id, 7, '0', STR_PAD_LEFT);

        $number .= $polis_number;

        return $number;
    }


    public function get_operation_insurance($operation_id)
    {
        $query = $this->db->placehold("
            SELECT * 
            FROM __insurances
            WHERE operation_id = ?
        ", (int)$operation_id);
        $this->db->query($query);
        $result = $this->db->result();

        return $result;
    }

    public function get_insurance($id)
    {
        $query = $this->db->placehold("
            SELECT * 
            FROM __insurances
            WHERE id = ?
        ", (int)$id);
        $this->db->query($query);
        $result = $this->db->result();

        return $result;
    }

    public function get_insurances($filter = array())
    {
        $id_filter = '';
        $user_id_filter = '';
        $order_filter = '';
        $sent_status_filter = '';
        $keyword_filter = '';
        $limit = 1000;
        $page = 1;

        if (!empty($filter['id']))
            $id_filter = $this->db->placehold("AND id IN (?@)", array_map('intval', (array)$filter['id']));

        if (!empty($filter['user_id']))
            $user_id_filter = $this->db->placehold("AND user_id IN (?@)", array_map('intval', (array)$filter['user_id']));

        if (isset($filter['sent']))
            $sent_status_filter = $this->db->placehold("AND sent_status = ?", (int)$filter['sent']);

        if (isset($filter['order']))
            $order_filter = $this->db->placehold("AND contract_id = ?", (int)$filter['order']);

        if (isset($filter['keyword'])) {
            $keywords = explode(' ', $filter['keyword']);
            foreach ($keywords as $keyword)
                $keyword_filter .= $this->db->placehold('AND (name LIKE "%' . $this->db->escape(trim($keyword)) . '%" )');
        }

        if (isset($filter['limit']))
            $limit = max(1, intval($filter['limit']));

        if (isset($filter['page']))
            $page = max(1, intval($filter['page']));

        $sql_limit = $this->db->placehold(' LIMIT ?, ? ', ($page - 1) * $limit, $limit);

        $query = $this->db->placehold("
            SELECT * 
            FROM __insurances
            WHERE 1
                $id_filter
                $user_id_filter
				$sent_status_filter
                $keyword_filter
                $order_filter
            ORDER BY id ASC 
            $sql_limit
        ");
        $this->db->query($query);
        $results = $this->db->results();

        return $results;
    }

    public function count_insurances($filter = array())
    {
        $id_filter = '';
        $user_id_filter = '';
        $sent_status_filter = '';
        $keyword_filter = '';

        if (!empty($filter['id']))
            $id_filter = $this->db->placehold("AND id IN (?@)", array_map('intval', (array)$filter['id']));

        if (!empty($filter['user_id']))
            $user_id_filter = $this->db->placehold("AND user_id IN (?@)", array_map('intval', (array)$filter['user_id']));

        if (isset($filter['sent']))
            $sent_status_filter = $this->db->placehold("AND sent_status = ?", (int)$filter['sent']);

        if (isset($filter['keyword'])) {
            $keywords = explode(' ', $filter['keyword']);
            foreach ($keywords as $keyword)
                $keyword_filter .= $this->db->placehold('AND (name LIKE "%' . $this->db->escape(trim($keyword)) . '%" )');
        }

        $query = $this->db->placehold("
            SELECT COUNT(id) AS count
            FROM __insurances
            WHERE 1
                $id_filter
                $user_id_filter
                $sent_status_filter
                $keyword_filter
        ");
        $this->db->query($query);
        $count = $this->db->result('count');

        return $count;
    }

    public function add_insurance($insurance)
    {
        $insurance = (array)$insurance;

        $query = $this->db->placehold("
            INSERT INTO __insurances SET ?%
        ", $insurance);
        $this->db->query($query);
        $id = $this->db->insert_id();

        $insert =
            [
                'className' => self::class,
                'log' => $id,
                'params' => $query
            ];

        LogsORM::insert($insert);

        $insurance_number = $this->create_number($id);

        $this->update_insurance($id, array('number' => $insurance_number));

        return $id;
    }

    public function update_insurance($id, $insurance)
    {
        $query = $this->db->placehold("
            UPDATE __insurances SET ?% WHERE id = ?
        ", (array)$insurance, (int)$id);
        $this->db->query($query);

        return $id;
    }

    public function delete_insurance($id)
    {
        $query = $this->db->placehold("
            DELETE FROM __insurances WHERE id = ?
        ", (int)$id);
        $this->db->query($query);
    }
}