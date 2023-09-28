import { React, useContext } from 'react'
import { PieChart } from '@mui/x-charts/PieChart';
import ThemeContext from '../context/ThemeContext';

function Legend(props) {
    let { theme } = useContext(ThemeContext);
    let data = props.data
    return (
        <div className={`flex flex-row h-6 m-2 font-semibold text-sm`}>
            <div className='w-6' style={{
                backgroundColor: data.color
            }}></div>
            <div className={`h-6 text-black pl-3 ${theme}-c1 flex items-center`}>
                {data.label}
            </div>
        </div>
    )
}

function PieChartWrapper(props) {
  const sizing = {
    legend: { hidden: true },
  };
  return (
    <div className='flex flex-row h-fit'>
        <div className='sm:w-80 w-64 flex justify-end'>
            <PieChart
            series={[
            {
                data: props.data,
                innerRadius: 35,
                outerRadius: 100,
                cx: 90
            },
            ]}
            width={200}
            height={250}
            {...sizing}
        />
      </div>
      <div className='flex flex-col justify-center w-24'>
        {
            props.data.map((category)=>{
                return(<Legend data={category}/>)
            })
        }
      </div>
    </div>
  )
}

export default PieChartWrapper