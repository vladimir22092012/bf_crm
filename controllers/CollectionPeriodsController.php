<?php

class CollectionPeriodsController extends Controller
{
    public function fetch()
    {
        if ($this->request->method('post')) {
            switch ($this->request->post('action', 'string')):

                case 'getPeriod':
                    $this->getPeriod();
                    break;

                case 'editPeriod':
                    $this->editPeriod();
                    break;

                case 'addPeriod':
                    $this->addPeriod();
                    break;

                case 'deletePeriod':
                    $this->deletePeriod();
                    break;

            endswitch;
        }

        $periods = CollectorPeriodsORM::get();
        $this->design->assign('periods', $periods);

        
        return $this->design->fetch('collection_periods.tpl');
    }

    private function getPeriod()
    {
        $id = $this->request->post('id');
        $period = CollectorPeriodsORM::find($id);

        echo json_encode($period);
        exit;
    }

    private function editPeriod()
    {
        $name = $this->request->post('name');
        $periodFrom = $this->request->post('period_from');
        $periodTo = $this->request->post('period_to');
        $id = $this->request->post('id');

        $insert =
            [
                'name' => $name,
                'period_from' => $periodFrom,
                'period_to' => $periodTo,
            ];

        CollectorPeriodsORM::where('id', $id)->update($insert);
        exit;
    }

    private function addPeriod()
    {
        $name = $this->request->post('name');
        $periodFrom = $this->request->post('period_from');
        $periodTo = $this->request->post('period_to');

        $insert =
            [
                'name' => $name,
                'period_from' => $periodFrom,
                'period_to' => $periodTo,
            ];

        CollectorPeriodsORM::insert($insert);
        exit;
    }

    private function deletePeriod()
    {
        $id = $this->request->post('id');
        CollectorPeriodsORM::destroy($id);
        exit;
    }
    
}