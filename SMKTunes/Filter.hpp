/*! @file
@brief フィルターの原型(インタフェース)
@author Masato WATANABE
@date 2008/7/1 作成 PushInputとClearBufferを純粋仮想関数として実装
*/

#pragma once

class CFilter {
public:
	CFilter(){};
	virtual ~CFilter(){};

	virtual double PushInput(double)=0;
	virtual void ClearBuffer()=0;
};