import { React, useState, useEffect, useContext } from 'react'
import { useParams } from 'react-router-dom';
import ThemeContext from '../../context/ThemeContext';
import TransactionBox from './TransactionBox';
import { BACKEND_API_URL, theme_colors } from '../../config';
import ApiGet from '../../axios/getapi';
import Transactions from '../Transactions';
import KeyboardArrowLeftIcon from '@mui/icons-material/KeyboardArrowLeft';
import KeyboardArrowRightIcon from '@mui/icons-material/KeyboardArrowRight';

function PaginateTransactions(props) {
  const { theme } = useContext(ThemeContext);
  const [data, setData] = useState(null)
  const [page_number, set_page_number] = useState(1)
  console.log(page_number)
  const page_size = props.page_size
  let { id } = useParams();

  const reducePageNumber = () => {
    if (page_number <= 1){
        return
    }else{
        set_page_number(page_number-1)
    }
  }

  const increasePageNumber = () => {
    if (page_number <= 1){
        return
    }else{
        set_page_number(page_number+1)
    }
  }
  
  let url = `${BACKEND_API_URL}/accounts/${id}/paginate_transactions?page_size=${page_size}&page_number=${page_number}`
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(url);
        console.log(response.data);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }
    temp();
  }, [url])

  if (!data){
    return <></>
  }
  return (
    <div className={`sm:w-[450px] w-full rounded overflow-hidden flex-col`}>
        <Transactions data={data} header='Transactions' theme={theme}/>
        <div className='flex flex-row justify-evenly'>
            <div onClick={reducePageNumber}>
                <KeyboardArrowLeftIcon style={{
                    height: '3rem',
                    width: '3rem',
                    color: theme_colors[`${theme}_c1`]
                }}/>
            </div>
            <div className={`h-12 text-lg font-semibold w-12 flex items-center justify-center ${theme}-c1`} style={{
                fontSize: '1.5rem'
            }}>{page_number}</div>
            <div>
                <KeyboardArrowRightIcon style={{
                    height: '3rem',
                    width: '3rem',
                    color: theme_colors[`${theme}_c1`]
                }}
                onClick={()=>{set_page_number(page_number+1)}}/>
            </div>
            
        </div>
    </div>
  )
}

export default PaginateTransactions