/*

DU3456SEM.CPP

JY

Mlaskal's semantic interface for DU3-6

*/

#include "du3456sem.hpp"
#include "duerr.hpp"

namespace mlc {


	std::string GetNumberFromWrongNumber(std::string wrongNumber, std::regex reg, std::string raplacement) {

		return std::regex_replace(wrongNumber, reg, raplacement);
	}



};

/*****************************************/