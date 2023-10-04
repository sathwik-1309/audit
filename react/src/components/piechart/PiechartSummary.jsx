import { React, useContext } from 'react';
import ThemeContext from '../../context/ThemeContext';
import PieChartWrapper from '../PieChartWrapper';

function PiechartSummary(props) {
    let data = props.data
    let { theme } = useContext(ThemeContext);
  return (
    <div className='flex flex-col sm:m-3'>
        <div className={`font-bold ${theme}-c1`}>{props.header}</div>
        <PieChartWrapper data={data}/>
        {
            data.length !== 0 &&
            <div className={`${theme}-bg3 w-96 p-1 rounded ${theme}-c1 m-2`}>
                <div className={`flex flex-row h-12 ${theme}-bg2 m-2 rounded items-center font-bold ${theme}-c2`} style={{ fontSize: '0.9rem'}}>
                    <div className='w-1/3'>{props.header}</div>
                    <div className='w-1/3'>Spent</div>
                    <div className='w-1/3'>%</div>
                </div>
                {
                    data.map((category)=>{
                        return(
                            <div className={`flex flex-row h-10 ${theme}-bg1 m-2 rounded items-center font-semibold`}>
                                <div className='w-1/3'>{category.label}</div>
                                <div className='w-1/3'>₹ {category.value}</div>
                                <div className='w-1/3'>{category.percentage} %</div>
                            </div>
                        )
                    })
                }
            </div>
        }
    </div>
  )
}

export default PiechartSummary