import { Injectable } from '@nestjs/common';
import { AppReqDto, AppResDto } from './dto/app.dto';

@Injectable()
export class AppService {
  getHello(dto: AppReqDto): AppResDto {
    return {
      message: `Hello ${dto.name}!`,
    };
  }
}
