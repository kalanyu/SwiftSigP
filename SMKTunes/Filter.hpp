/*! @file
@brief �t�B���^�[�̌��^(�C���^�t�F�[�X)
@author Masato WATANABE
@date 2008/7/1 �쐬 PushInput��ClearBuffer���������z�֐��Ƃ��Ď���
*/

#pragma once

class CFilter {
public:
	CFilter(){};
	virtual ~CFilter(){};

	virtual double PushInput(double)=0;
	virtual void ClearBuffer()=0;
};